xquery version "1.0-ml";

(: This module provides access to the raw database,
   which the setup scripts use to import content :)

module namespace raw = "http://marklogic.com/rundmc/raw-docs-access";

import module namespace ml="http://developer.marklogic.com/site/internal"
       at "../../model/data-access.xqy";

import module namespace u="http://marklogic.com/rundmc/util"
       at "../../lib/util-2.xqy";

declare variable $raw:db-name := fn:string(u:get-doc("/apidoc/config/source-database.xml"));

declare variable $raw:common-import :=
                 'import module namespace api = "http://marklogic.com/rundmc/api" at "/apidoc/model/data-access.xqy";
                  declare namespace apidoc="http://marklogic.com/xdmp/apidoc";';

declare variable $raw:common-options := <options xmlns="xdmp:eval">
                                          <database>{xdmp:database($raw:db-name)}</database>
                                        </options>;

declare variable $raw:api-docs :=
  let $query := fn:concat($raw:common-import, 'xdmp:directory(fn:concat("/",$api:version,"/apidoc/")) [apidoc:module]')
  return
    xdmp:eval($query, (), $raw:common-options);

declare variable $raw:guide-docs :=
  let $query := fn:concat($raw:common-import, 'xdmp:directory(fn:concat("/",$api:version,"/docs/"))')
  return
    xdmp:eval($query, (), $raw:common-options);


declare function get-doc($uri) {
  let $query := fn:concat('fn:doc("',$uri,'")')
  return 
    xdmp:eval($query, (), $raw:common-options)
};

(: Translate the URI of the raw, combined guide to the URI of the final target guide;
   store all the final guides in /apidoc :)
declare function target-guide-uri($guide as document-node()) {
  fn:concat("/apidoc",fn:base-uri($guide))
};