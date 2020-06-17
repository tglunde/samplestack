CREATE OR REPLACE python3 scalar SCRIPT STAGING.VI_XMLPARSE() RETURNS INT AS 
from lxml import etree
import requests

global_col = dict()

def fast_iter(exactx, global_xpath, local_xpath, context, func, *args, **kwargs):
    for event, elem in context:
        func(exactx, global_xpath, local_xpath, elem, *args, **kwargs)
        elem.clear()
        for ancestor in elem.xpath('ancestor-or-self::*'):
            while ancestor.getprevious() is not None:
                del ancestor.getparent()[0]
    del context


def process_element(exactx, global_xpath, local_xpath, elem):
    global global_col
    if elem.xpath(global_xpath[0]):
        for xpath in global_xpath:
            global_col[xpath]=''
    for xpath in global_xpath:
        if elem.xpath(xpath):
            global_col[xpath] = ''.join(filter(None, elem.xpath(xpath+'/text()')))
    col = dict()
    for xpath in local_xpath:
        if elem.xpath(xpath):
            col[xpath] = ''.join(filter(None, elem.xpath(xpath+'/text()')))
    current_row = list()
    for xpath in global_xpath:
        if xpath in global_col:
            current_row.append(global_col[xpath])
        else: 
            current_row.append('')
    for xpath in local_xpath:
        if xpath in col:
            current_row.append(col[xpath])
        else:
            current_row.append('')
    exactx.emit(*current_row)

def parse(exactx, global_xpath, local_xpath, local_tag, url, user, password):
    with requests.get(url, stream=True, auth=(user,password) ) as r:
        if r.encoding is None:
            r.encoding = 'utf-8'
        context = etree.iterparse( r.raw, tag=local_tag )
        fast_iter(exactx, global_xpath, local_xpath, context, process_element)

def parse_delivery(exactx, url, user, password):
    global_xpath = [
        '../../DeliveryData/deliveryUniqueIdentifier',
        '../../DeliveryData/CBDNumber',
        '../../DeliveryData/revisionALM',
        '../../DeliveryData/title',
        '../../DeliveryData/customer',
        '../../DeliveryData/deliveredDate',
        '../../DeliveryData/deliveryType',
        '../../DeliveryData/deliveryNumber',
        '../../DeliveryData/ECUname',
        '../../DeliveryData/inDBDate',
        '../../DeliveryData/productTitle',
        '../../DeliveryData/programTitle',
        '../../DeliveryData/relType',
        '../../DeliveryData/bIsBeta',
        '../../DeliveryData/bIsSafetyRelevantc',
        '../../DeliveryData/testedDerivate'
    ]
    local_xpath = [
        './CmpPkgName',
        './Version'
    ]
    local_tag = 'CmpPrcPkgVersClass'
    parse(exactx, global_xpath, local_xpath, local_tag, url, user, password)

def parse_metric(exactx, url, user, password):
    global_xpath = [
        '../../../../name',
        '../../version',
        '../../name'
    ]
    local_xpath = [
        './name',
        './value'
    ]
    local_tag = 'Metrics'
    parse(exactx, global_xpath, local_xpath, local_tag, url, user, password)

def parse_component(exactx, url, user, password):
    global_xpath = [
    '../../../../guid', # namespace guid
    '../../../../Name', # namespace name
    '../../guid', # package guid
    '../../Name', # package name
    '../../m_CmpPkgDataClass/AutosarCluster', # AutoSarCluster CmpPackage/m_CmpPkgDataClass
    '../../m_CmpPkgDataClass/CurrentQualityProcess', 
    '../../m_CmpPkgDataClass/Description', 
    '../../m_CmpPkgDataClass/HasSafetyRequirements', 
    '../../m_CmpPkgDataClass/Layer', 
    '../../m_CmpPkgDataClass/ReportClassification', 
    '../../m_CmpPkgDataClass/ReportingQStatus', 
    '../../m_CmpPkgDataClass/ShortName', 
    '../../m_CmpPkgDataClass/TargetQualityProcess', 
    '../../m_CmpPkgDataClass/TargetQualityStatus', 
    '../../m_CmpPkgDataClass/UsedInProduct',
    '../../m_CmpPkgDataClass/userGuidResponsible'
    ]
    local_xpath = [
        './guid',
        './Version',
        './ImplementationVersion',
        './CreationDateALM',
        './modTimeALM',
        './revisionALM',
        './CreationDateSvn',
        './revisionSvn',
        './LastModDate',
        './serverURL',
        './description',
        './pathTestReports',
        './QAApprovalNote',
        './QACheck',
        './qLevel',
        './releaseStatement',
        './revisionTestReports'
    ]
    local_tag = 'CmpPkgVersionDataClass'
    parse(exactx, global_xpath, local_xpath, local_tag, url, user, password)

def parse_release(exactx, url, user, password):
    global_xpath = [
    '../../../../ProductName',
    '../../CreationDateALM',
    '../../CreationDateSvn',
    '../../guid',
    '../../LastModDate',
    '../../modTimeALM',
    '../../revisionALM',
    '../../revisionSvn',
    '../../Version'
    ]
    local_xpath = [
        './guid',
        './CmpPkgName',
        './Version'
    ]
    local_tag = 'CmpPkgVersion'
    parse(exactx, global_xpath, local_xpath, local_tag, url, user, password)
/