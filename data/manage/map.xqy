(:
Copyright 2011 MarkLogic Corporation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
:)

xquery version "1.0-ml";

import module namespace manage="http://marklogic.com/mljson/manage" at "../lib/manage.xqy";
import module namespace common="http://marklogic.com/mljson/common" at "../lib/common.xqy";
import module namespace json="http://marklogic.com/json" at "../lib/json.xqy";

import module namespace rest="http://marklogic.com/appservices/rest" at "../lib/rest/rest.xqy";
import module namespace endpoints="http://marklogic.com/mljson/endpoints" at "/config/endpoints.xqy";

declare option xdmp:mapping "false";


let $params := rest:process-request(endpoints:request("/data/manage/map.xqy"))
let $name := map:get($params, "name")
let $key := map:get($params, "key")
let $element := map:get($params, "element")
let $mode := map:get($params, "mode")
let $requestMethod := xdmp:get-request-method()

let $existing := manage:getMap($name)

return
    if($requestMethod = "GET")
    then
        if(exists($existing))
        then json:xmlToJSON($existing)
        else common:error(404, "Mapping not found", "json")

    else if($requestMethod = "POST")
    then 
        if((empty($key) and empty($element)) or (exists($key) and exists($element)))
        then common:error(500, "Must supply either a JSON key or XML element name", "json")
        else if(not($mode = ("equals", "contains")))
        then common:error(500, "Map modes must be either 'equals' or 'contains'", "json")
        else if(exists(manage:validateIndexName($name)))
        then common:error(500, manage:validateIndexName($name), "json")
        else if(exists($key))
        then manage:createJSONMap($name, $key, $mode)
        else if(exists($element))
        then manage:createXMLMap($name, $element, $mode)
        else ()

    else if($requestMethod = "DELETE")
    then
        if(exists($existing))
        then manage:deleteMap($name)
        else common:error(404, "Mapping not found", "json")
    else ()
