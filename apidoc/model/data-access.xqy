xquery version "1.0-ml";

            module namespace api = "http://marklogic.com/rundmc/api";
declare default function namespace "http://marklogic.com/rundmc/api";

declare namespace apidoc = "http://marklogic.com/xdmp/apidoc";

import module namespace u = "http://marklogic.com/rundmc/util"
       at "../../lib/util-2.xqy";

declare variable $api:toc-url-location := "/apidoc/private/tocURL.xml";
declare variable $api:toc-url := fn:string(fn:doc($toc-url-location)/*);

declare variable $api:query-for-builtin-functions :=
  cts:element-attribute-value-query(xs:QName("api:function"),
                                    xs:QName("type"),
                                    "builtin");

(: Every function that's not a built-in function is a library function :)
declare variable $api:query-for-library-functions :=
   cts:element-query(
     xs:QName("api:function"),
     cts:not-query($api:query-for-builtin-functions)
   );

declare variable $api:built-in-function-count  := xdmp:estimate(cts:search(fn:collection(),$api:query-for-builtin-functions));
declare variable $api:library-function-count   := xdmp:estimate(cts:search(fn:collection(),$api:query-for-library-functions));

declare variable $api:built-in-libs := get-libs($api:query-for-builtin-functions, fn:true() );
declare variable $api:library-libs  := get-libs($api:query-for-library-functions, fn:false());

declare function get-libs($query, $builtin) {
  for $lib in cts:element-attribute-values(xs:QName("api:function"),
                                           xs:QName("lib"), (), "ascending",
                                           $query)
  return
    <wrapper> <!-- wrapper necessary for XSLTBUG 13062 workaround re: processing of parentless elements -->
      <api:lib>{
         $lib
      }</api:lib>
    </wrapper>
    /api:lib
};

declare function function-count-for-lib($lib) {
  xdmp:estimate(fn:collection()/api:function-page/api:function[@lib eq $lib])
};

declare function function-names-for-lib($lib) {

  let $query := cts:element-attribute-value-query(xs:QName("api:function"),
                                                  xs:QName("lib"),
                                                  $lib)
  return
  for $func in cts:element-attribute-values(xs:QName("api:function"),
                                            xs:QName("fullname"), (), "ascending",
                                            $query)
    return
      <api:function-name>{ $func }</api:function-name>
};


declare variable $namespace-mappings := u:get-doc("/apidoc/config/namespace-mappings.xml")/namespaces/namespace;

(: Returns the namespace URI associated with the given lib name :)
declare function uri-for-lib($lib) {
  fn:string($namespace-mappings[@lib eq $lib]/@uri)
};

(: Normally, just use the lib name as the prefix, unless specially configured to do otherwise :)
declare function prefix-for-lib($lib) {
  fn:string($namespace-mappings[@lib eq $lib]/(if (@prefix) then @prefix else $lib))
};


declare function make-list-page($functions, $descriptor, $are-namespace-specific) {

  document {
    (: Being careful to avoid the element name "api:function", which we've reserved already :)
    <api:function-list-page title-prefix="{$descriptor}" disable-comments="yes">{

      if ($are-namespace-specific) then
        let $prefix := $descriptor,
            $ns-uri := api:uri-for-lib($prefix) return
         (attribute namespace { $ns-uri },
          attribute prefix    { $prefix }
         )
      else (),

      for $func in $functions order by $func/@fullname return
        <api:function-listing>
          <api:name>{
            (: Special-case the cts accessor functions; they should be indented :)
            if ($func/@lib eq 'cts' and fn:contains($func/@fullname,"-query-"))
            then attribute indent {"yes"}
            else (),

            fn:string($func/@fullname)
          }</api:name>
          <api:description>{
            (: Use the same code that docapp uses for extracting the summary (first line) :)
            fn:concat(fn:tokenize($func/apidoc:summary,"\.(\s+|\s*$)")[1], ".")
          }</api:description>
        </api:function-listing>

    }</api:function-list-page>
  }
};
