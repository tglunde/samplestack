
select
    distinct
    dlvry.DELIVERY_CUSTOMER as customer,
    dlvry.DELIVERY_GUID as delivery_guid,
    dlvry.DELIVERY_CBDNUMBER as delivery_cbd_number,
    dlvry.DELIVERY_DELIVERYNUMBER as delivery_number,
    dlvry.DELIVERY_GUID as t_cmp_delivery_guid
from
    {{ source( 'qstat_xml_files', 'XMLINTERFACE_R_VI_XML_DELIVERY_U_STAGING') }} dlvry

