select 
    xmlcomponent_h,xmlcomponent_bk,xmlcomponent_lt,xmlcomponent_s
from {{ source('xml', 'vi_xml_component') }}