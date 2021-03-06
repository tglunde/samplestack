CREATE OR REPLACE TABLE event (ldts TIMESTAMP, event_name VARCHAR(200), event_json VARCHAR(2000000) UTF8);


INSERT INTO EXA_TOOLBOX.EVENT (to_timestamp('2015-11-26T08:43:13.827Z','YYYY-MM-DDTHH24:MI:SS.FFFZ'), '', '');


SELECT to_timestamp('2015-11-26 08:43:13.827Z','YYYY-MM-DD HH24:MI:SS.FF3Z');


INSERT INTO EXA_TOOLBOX.EVENT VALUES (to_timestamp('2015-11-26 08:43:13.827','YYYY-MM-DD HH24:MI:SS.FF3'),'name','.');


SELECT ldts,event_name,isjson(event_json) FROM event 


DROP TABLE IF EXISTS result_table;

EXECUTE SCRIPT flat_json_table ( 'EXA_TOOLBOX', 'EVENT', 'EVENT_JSON', 'EXA_TOOLBOX', 'RESULT_TABLE', false, 2);

INSERT INTO EXA_TOOLBOX.EVENT (LDTS,EVENT_NAME,EVENT_JSON) VALUES 
('2015-11-26 08:43:13.827','1503078_Description','{
  "ALM_PACKAGE_NAMESPACE": {
    "title": "TestApp",
    "guid": "PCKGNS-49EB228F-9587-433C-B6F7-C1825B0D9EF9"
  },
  "changesetNumber": 1503078,
  "ALM_PACKAGE_SUBPACKAGE": {
    "title": "Description",
    "rootPackage": "false",
    "guid": "PCKG-ABD84952-0C97-4A09-82A0-1205730700EF"
  },
  "ALM_PACKAGE_BASE": {
    "title": "TestApp_EtiTcpIp_Ixia",
    "componentShortName": "EtiTcpIpIx",
    "guid": "PCKGBASE-C294324B-4937-4808-BED8-1A305BD8920D"
  },
  "DEPENDENCIES": [],
  "ALM_PACKAGE_INSTANCE": {
    "title": "2.00.01",
    "guid": "PCKGINST-ADFE3825-1FA8-46B7-9546-0BADDF611DAC"
  },
  "timestamp": "2015-11-26T08:43:13.827Z"
}')
,('2015-11-26 08:43:13.827','1503078_DocTechref','{
  "ALM_PACKAGE_NAMESPACE": {
    "title": "TestApp",
    "guid": "PCKGNS-49EB228F-9587-433C-B6F7-C1825B0D9EF9"
  },
  "changesetNumber": 1503078,
  "ALM_PACKAGE_SUBPACKAGE": {
    "title": "Doc_TechRef",
    "rootPackage": "false",
    "guid": "PCKG-06737886-64A0-4DDA-86E5-3D12884734DF"
  },
  "ALM_PACKAGE_BASE": {
    "title": "TestApp_EtiTcpIp_Ixia",
    "componentShortName": "EtiTcpIpIx",
    "guid": "PCKGBASE-C294324B-4937-4808-BED8-1A305BD8920D"
  },
  "DEPENDENCIES": [],
  "ALM_PACKAGE_INSTANCE": {
    "title": "1.03.00",
    "guid": "PCKGINST-E1F7D75A-63CF-4540-A505-5834496C366F"
  },
  "timestamp": "2015-11-26T08:43:13.827Z"
}')
,('2015-11-26 08:43:13.827','1503078_Generator','{
  "ALM_PACKAGE_NAMESPACE": {
    "title": "TestApp",
    "guid": "PCKGNS-49EB228F-9587-433C-B6F7-C1825B0D9EF9"
  },
  "changesetNumber": 1503078,
  "ALM_PACKAGE_SUBPACKAGE": {
    "title": "GenTool_GeneratorMsr",
    "rootPackage": "false",
    "guid": "PCKG-77FA781E-D9A3-4893-9D05-2A526C64E50C"
  },
  "ALM_PACKAGE_BASE": {
    "title": "TestApp_EtiTcpIp_Ixia",
    "componentShortName": "EtiTcpIpIx",
    "guid": "PCKGBASE-C294324B-4937-4808-BED8-1A305BD8920D"
  },
  "DEPENDENCIES": [],
  "ALM_PACKAGE_INSTANCE": {
    "title": "2.00.01",
    "guid": "PCKGINST-C307E09C-2FA9-4692-8820-22A69F6E39AA"
  },
  "timestamp": "2015-11-26T08:43:13.827Z"
}')
,('2015-11-26 08:43:13.827','1503078_impl','{
  "ALM_PACKAGE_NAMESPACE": {
    "title": "TestApp",
    "guid": "PCKGNS-49EB228F-9587-433C-B6F7-C1825B0D9EF9"
  },
  "changesetNumber": 1503078,
  "ALM_PACKAGE_SUBPACKAGE": {
    "title": "Implementation",
    "rootPackage": "false",
    "guid": "PCKG-F30F3D30-3E5B-4265-A7AC-A647E0592C77"
  },
  "ALM_PACKAGE_BASE": {
    "title": "TestApp_EtiTcpIp_Ixia",
    "componentShortName": "EtiTcpIpIx",
    "guid": "PCKGBASE-C294324B-4937-4808-BED8-1A305BD8920D"
  },
  "DEPENDENCIES": [],
  "ALM_PACKAGE_INSTANCE": {
    "title": "2.00.01",
    "guid": "PCKGINST-F6E540EF-E8C6-45AC-A2AA-EA6CB5F9C076"
  },
  "timestamp": "2015-11-26T08:43:13.827Z"
}')
,('2015-11-26 08:43:13.827','1503078_make','{
  "ALM_PACKAGE_NAMESPACE": {
    "title": "TestApp",
    "guid": "PCKGNS-49EB228F-9587-433C-B6F7-C1825B0D9EF9"
  },
  "changesetNumber": 1503078,
  "ALM_PACKAGE_SUBPACKAGE": {
    "title": "Make",
    "rootPackage": "false",
    "guid": "PCKG-6C05A809-18B5-4A95-89CF-BEF39FEF4470"
  },
  "ALM_PACKAGE_BASE": {
    "title": "TestApp_EtiTcpIp_Ixia",
    "componentShortName": "EtiTcpIpIx",
    "guid": "PCKGBASE-C294324B-4937-4808-BED8-1A305BD8920D"
  },
  "DEPENDENCIES": [],
  "ALM_PACKAGE_INSTANCE": {
    "title": "2.00.00",
    "guid": "PCKGINST-C796DE2A-6227-4A0E-9629-ED5FEF2C91D1"
  },
  "timestamp": "2015-11-26T08:43:13.827Z"
}')
,('2015-11-26 08:43:13.827','1503078_root','{
  "ALM_PACKAGE_NAMESPACE": {
    "title": "TestApp",
    "guid": "PCKGNS-49EB228F-9587-433C-B6F7-C1825B0D9EF9"
  },
  "changesetNumber": 1503078,
  "ALM_PACKAGE_SUBPACKAGE": {
    "title": "root",
    "rootPackage": "true",
    "guid": "PCKG-9D47D060-7059-4D39-A4BD-03D744F31841"
  },
  "ALM_PACKAGE_BASE": {
    "title": "TestApp_EtiTcpIp_Ixia",
    "componentShortName": "EtiTcpIpIx",
    "guid": "PCKGBASE-C294324B-4937-4808-BED8-1A305BD8920D"
  },
  "DEPENDENCIES": [
    {
      "dependentPackageInstanceGuid": "PCKGINST-E1F7D75A-63CF-4540-A505-5834496C366F"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-F6E540EF-E8C6-45AC-A2AA-EA6CB5F9C076"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-C307E09C-2FA9-4692-8820-22A69F6E39AA"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-ADFE3825-1FA8-46B7-9546-0BADDF611DAC"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-C796DE2A-6227-4A0E-9629-ED5FEF2C91D1"
    }
  ],
  "ALM_PACKAGE_INSTANCE": {
    "title": "2.00.01",
    "guid": "PCKGINST-A1E84C55-7689-4901-9760-E8A500F4DFAB"
  },
  "timestamp": "2015-11-26T08:43:13.827Z"
}')
,('2019-04-16 09:25:55.340','3239542_Make','{
  "ALM_PACKAGE_NAMESPACE": {
    "title": "SysService",
    "guid": "PCKGNS-EBA7F635-C4CC-9F41-947C-90755BAFB8A2"
  },
  "changesetNumber": 3239542,
  "ALM_PACKAGE_SUBPACKAGE": {
    "title": "Make",
    "rootPackage": "false",
    "guid": "PCKG-6C05A809-18B5-4A95-89CF-BEF39FEF4470"
  },
  "ALM_PACKAGE_BASE": {
    "userProperties": {
      "Component.CurrentQualityProcess": "Process3",
      "Component.HasSafetyRequirements": "no",
      "Component.Layer": "SLP",
      "Component.TargetQualityStatus": "QM",
      "Component.TargetQualityProcess": "Process3",
      "SWCP.TargetFolder": "Etm",
      "Component.UsedInProduct": "MSR4",
      "Component.ReportClassification": "Component",
      "Component.AutosarCluster": "ETH"
    },
    "componentShortName": "Etm",
    "guid": "PCKGBASE-C294324B-4937-4808-BED8-1A305BD8920D",
    "title": "SysService_AsrEtm"
  },
  "DEPENDENCIES": [],
  "ALM_PACKAGE_INSTANCE": {
    "title": "5.00.02",
    "guid": "PCKGINST-44F0B627-C227-46D7-A9A2-1EBAA2E0CE32"
  },
  "timestamp": "2019-04-16T09:25:55.340Z"
}')
,('2020-01-15 14:26:17.267','3673632_Description','{
  "ALM_PACKAGE_NAMESPACE": {
    "title": "SysService",
    "guid": "PCKGNS-EBA7F635-C4CC-9F41-947C-90755BAFB8A2"
  },
  "changesetNumber": 3673632,
  "ALM_PACKAGE_SUBPACKAGE": {
    "title": "Description",
    "rootPackage": "false",
    "guid": "PCKG-ABD84952-0C97-4A09-82A0-1205730700EF"
  },
  "ALM_PACKAGE_BASE": {
    "userProperties": {
      "Component.CurrentQualityProcess": "Process3",
      "Component.HasSafetyRequirements": "no",
      "Component.Layer": "SLP",
      "Component.TargetQualityStatus": "QM",
      "Component.TargetQualityProcess": "Process3",
      "SWCP.TargetFolder": "Etm",
      "Component.UsedInProduct": "MSR4",
      "Component.ReportClassification": "Component",
      "Component.AutosarCluster": "ETH"
    },
    "componentShortName": "Etm",
    "guid": "PCKGBASE-C294324B-4937-4808-BED8-1A305BD8920D",
    "title": "SysService_AsrEtm"
  },
  "DEPENDENCIES": [],
  "ALM_PACKAGE_INSTANCE": {
    "title": "8.00.03",
    "guid": "PCKGINST-EFAE5B85-60EA-40D0-9A69-BDB97C21C5F2"
  },
  "timestamp": "2020-01-15T14:26:17.267Z"
}')
,('2020-01-15 14:26:17.267','3673632_DocTechref','{
  "ALM_PACKAGE_NAMESPACE": {
    "title": "SysService",
    "guid": "PCKGNS-EBA7F635-C4CC-9F41-947C-90755BAFB8A2"
  },
  "changesetNumber": 3673632,
  "ALM_PACKAGE_SUBPACKAGE": {
    "title": "Doc_TechRef",
    "rootPackage": "false",
    "guid": "PCKG-06737886-64A0-4DDA-86E5-3D12884734DF"
  },
  "ALM_PACKAGE_BASE": {
    "userProperties": {
      "Component.CurrentQualityProcess": "Process3",
      "Component.HasSafetyRequirements": "no",
      "Component.Layer": "SLP",
      "Component.TargetQualityStatus": "QM",
      "Component.TargetQualityProcess": "Process3",
      "SWCP.TargetFolder": "Etm",
      "Component.UsedInProduct": "MSR4",
      "Component.ReportClassification": "Component",
      "Component.AutosarCluster": "ETH"
    },
    "componentShortName": "Etm",
    "guid": "PCKGBASE-C294324B-4937-4808-BED8-1A305BD8920D",
    "title": "SysService_AsrEtm"
  },
  "DEPENDENCIES": [],
  "ALM_PACKAGE_INSTANCE": {
    "title": "8.00.01",
    "guid": "PCKGINST-999736EF-D56B-4DC2-918E-DD5A2565ADA2"
  },
  "timestamp": "2020-01-15T14:26:17.267Z"
}')
,('2020-01-15 14:26:17.267','3673632_TscStandard','{
  "ALM_PACKAGE_NAMESPACE": {
    "title": "SysService",
    "guid": "PCKGNS-EBA7F635-C4CC-9F41-947C-90755BAFB8A2"
  },
  "changesetNumber": 3673632,
  "ALM_PACKAGE_SUBPACKAGE": {
    "title": "TscStandard",
    "rootPackage": "false",
    "guid": "PCKG-CC519D91-54A7-4DE2-8096-F8FDB8112BD7"
  },
  "ALM_PACKAGE_BASE": {
    "userProperties": {
      "Component.CurrentQualityProcess": "Process3",
      "Component.HasSafetyRequirements": "no",
      "Component.Layer": "SLP",
      "Component.TargetQualityStatus": "QM",
      "Component.TargetQualityProcess": "Process3",
      "SWCP.TargetFolder": "Etm",
      "Component.UsedInProduct": "MSR4",
      "Component.ReportClassification": "Component",
      "Component.AutosarCluster": "ETH"
    },
    "componentShortName": "Etm",
    "guid": "PCKGBASE-C294324B-4937-4808-BED8-1A305BD8920D",
    "title": "SysService_AsrEtm"
  },
  "DEPENDENCIES": [
    {
      "dependentPackageInstanceGuid": "PCKGINST-C201322A-EFD4-4487-93EB-BE6CF6416722"
    }
  ],
  "ALM_PACKAGE_INSTANCE": {
    "title": "1.07.00",
    "guid": "PCKGINST-EB197427-821E-4565-BED7-7F67B6BEBA85"
  },
  "timestamp": "2020-01-15T14:26:17.267Z"
}')
;
INSERT INTO EXA_TOOLBOX.EVENT (LDTS,EVENT_NAME,EVENT_JSON) VALUES 
('2020-01-15 14:26:17.267','3673632_impl','{
  "ALM_PACKAGE_NAMESPACE": {
    "title": "SysService",
    "guid": "PCKGNS-EBA7F635-C4CC-9F41-947C-90755BAFB8A2"
  },
  "changesetNumber": 3673632,
  "ALM_PACKAGE_SUBPACKAGE": {
    "title": "Implementation",
    "rootPackage": "false",
    "guid": "PCKG-F30F3D30-3E5B-4265-A7AC-A647E0592C77"
  },
  "ALM_PACKAGE_BASE": {
    "userProperties": {
      "Component.CurrentQualityProcess": "Process3",
      "Component.HasSafetyRequirements": "no",
      "Component.Layer": "SLP",
      "Component.TargetQualityStatus": "QM",
      "Component.TargetQualityProcess": "Process3",
      "SWCP.TargetFolder": "Etm",
      "Component.UsedInProduct": "MSR4",
      "Component.ReportClassification": "Component",
      "Component.AutosarCluster": "ETH"
    },
    "componentShortName": "Etm",
    "guid": "PCKGBASE-C294324B-4937-4808-BED8-1A305BD8920D",
    "title": "SysService_AsrEtm"
  },
  "DEPENDENCIES": [],
  "ALM_PACKAGE_INSTANCE": {
    "title": "8.00.02",
    "guid": "PCKGINST-D8523BA9-A584-4A28-9CBD-E6670001B4BE"
  },
  "timestamp": "2020-01-15T14:26:17.267Z"
}')
,('2020-04-01 06:14:52.980','3809515_Generator','{
  "ALM_PACKAGE_NAMESPACE": {
    "title": "SysService",
    "guid": "PCKGNS-EBA7F635-C4CC-9F41-947C-90755BAFB8A2"
  },
  "changesetNumber": 3809515,
  "ALM_PACKAGE_SUBPACKAGE": {
    "title": "GenTool_GeneratorMsr",
    "rootPackage": "false",
    "guid": "PCKG-77FA781E-D9A3-4893-9D05-2A526C64E50C"
  },
  "ALM_PACKAGE_BASE": {
    "userProperties": {
      "Component.CurrentQualityProcess": "Process3",
      "Component.HasSafetyRequirements": "no",
      "Component.Layer": "SLP",
      "Component.TargetQualityStatus": "QM",
      "Component.TargetQualityProcess": "Process3",
      "SWCP.TargetFolder": "Etm",
      "Component.UsedInProduct": "MSR4",
      "Component.ReportClassification": "Component",
      "Component.AutosarCluster": "ETH"
    },
    "componentShortName": "Etm",
    "guid": "PCKGBASE-C294324B-4937-4808-BED8-1A305BD8920D",
    "title": "SysService_AsrEtm"
  },
  "DEPENDENCIES": [],
  "ALM_PACKAGE_INSTANCE": {
    "title": "8.00.03",
    "guid": "PCKGINST-13A4B85A-7588-41EA-ABD6-55DE3C4966B3"
  },
  "timestamp": "2020-04-01T06:14:52.980Z"
}')
,('2020-04-01 06:14:52.980','3809515_root','{
  "ALM_PACKAGE_NAMESPACE": {
    "title": "SysService",
    "guid": "PCKGNS-EBA7F635-C4CC-9F41-947C-90755BAFB8A2"
  },
  "changesetNumber": 3809515,
  "ALM_PACKAGE_SUBPACKAGE": {
    "title": "root",
    "rootPackage": "true",
    "guid": "PCKG-9D47D060-7059-4D39-A4BD-03D744F31841"
  },
  "ALM_PACKAGE_BASE": {
    "userProperties": {
      "Component.CurrentQualityProcess": "Process3",
      "Component.HasSafetyRequirements": "no",
      "Component.Layer": "SLP",
      "Component.TargetQualityStatus": "QM",
      "Component.TargetQualityProcess": "Process3",
      "SWCP.TargetFolder": "Etm",
      "Component.UsedInProduct": "MSR4",
      "Component.ReportClassification": "Component",
      "Component.AutosarCluster": "ETH"
    },
    "componentShortName": "Etm",
    "guid": "PCKGBASE-C294324B-4937-4808-BED8-1A305BD8920D",
    "title": "SysService_AsrEtm"
  },
  "DEPENDENCIES": [
    {
      "dependentPackageInstanceGuid": "PCKGINST-EB197427-821E-4565-BED7-7F67B6BEBA85"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-D8523BA9-A584-4A28-9CBD-E6670001B4BE"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-44F0B627-C227-46D7-A9A2-1EBAA2E0CE32"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-999736EF-D56B-4DC2-918E-DD5A2565ADA2"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-13A4B85A-7588-41EA-ABD6-55DE3C4966B3"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-EFAE5B85-60EA-40D0-9A69-BDB97C21C5F2"
    }
  ],
  "ALM_PACKAGE_INSTANCE": {
    "title": "8.00.04",
    "qualityStatus": "QM",
    "guid": "PCKGINST-811F2480-7251-4DCD-A6A9-E39250343918"
  },
  "timestamp": "2020-04-01T06:14:52.980Z"
}')
,('2020-04-03 13:41:13.980','3816609_ProductRoot','{
  "ALM_PACKAGE_NAMESPACE": {
    "title": "MICROSAR4",
    "guid": "PCKGNS-09E91D0D-CCAD-439D-B737-E7A198C2F08C"
  },
  "changesetNumber": 3816609,
  "ALM_PACKAGE_SUBPACKAGE": {
    "title": "root",
    "rootPackage": "true",
    "guid": "PCKG-E8D84DCB-8B76-457A-84D0-DBE54EA09C6F"
  },
  "DEPENDENCIES": [
    {
      "dependentPackageInstanceGuid": "PCKGINST-63583F00-6451-4B6E-A46C-1FEE3C041B4F"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-71228245-F016-475C-9756-6524B5FE0B91"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-E1E593F1-C258-44D5-A914-DA57F893BB89"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-57559220-6BCE-4E23-A3A9-256A0CBBA824"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-78A06F1C-4993-40FF-A36B-428565BB28F9"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-6EBB7D38-40E4-4A9A-A46E-1FB5D8C2F254"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-04AC0646-696E-49F6-9093-6A0B20DF8B07"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-E40AC897-A288-4A4D-9070-8573FBD0BFCA"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-6A44D236-BA37-48AD-B36C-0F95224477AF"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-79111BE9-2A48-4CE9-AE89-F4A9B92520AB"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-3EA4BF6A-48AF-4D7E-AD44-406FFDA8D879"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-939FB1EE-E3FA-489A-B1DA-9D6E4EEFD716"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-8439BFB0-4780-403A-BFD3-8DF6F8B732FE"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-BF50D8E5-4548-4843-A354-BBCC4BA622E0"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-F4C2B0D5-60A4-430E-893C-87287D331DD0"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-7DF567EC-6E01-4B8F-ADB6-583579C3CE60"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-BDB4565A-8D7C-493B-B77C-3EF472C5BBD7"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-958F950A-93F4-41D7-9A4A-A7808B5F6673"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-CA372B58-B651-4BB5-802B-090A8D7A85C4"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-65C91C7D-5930-4049-8ECB-7F6F6A780360"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-13B7BCC8-7DD2-49A3-9D71-96FABB0DE6CA"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-E27A89D5-416B-49B4-81E3-1C9A0461FE22"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-A638BDF1-0FC4-43FE-B4D5-598B8B42C848"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-C6179652-73C0-426B-95A7-DE70964E1AF7"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-052C2D79-55AA-431E-A790-F5A70FB0360D"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-BDFA91CE-8019-4FBF-A4CF-E598A11993A9"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-0F36B2DC-659D-49D3-8433-5833FEC45BE4"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-A82C4824-3B6C-400F-BDBF-52ADAB9EAC33"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-0D91EDA1-51FC-4F8C-A201-9C53387332D4"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-49DDFECD-6D2C-4784-9A9A-C694C359FDFE"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-35A7DA06-9C82-493E-8869-88D890890F7C"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-74457629-3D1F-4165-B07A-27B639C88B37"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-6A86BD99-9F64-46EE-92BC-8007CC8BF125"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-3CA47A63-B743-4D24-B408-73A9010D17B4"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-51E8411A-ED4A-444B-B03E-6F9371E30197"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-C7AB64D7-CBA1-4DA1-8D32-E63AFDADD225"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-93686A8A-15AE-44BB-BA41-78835761D282"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-FCF26BD4-138D-4F84-87E3-BC7E099EF9E6"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-D569BAF7-BB53-4001-B451-A7D8B3D720D5"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-BA08D3B5-C980-4959-B566-A6A150389070"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-E1B30045-A63C-48A5-8CD6-2DC20A94921A"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-608CB02D-3FDF-4121-9580-F7DA4E5E8C13"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-56CC1169-746F-4132-AB85-87E3CB045FC4"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-E25F8071-9589-4BA5-8ED5-04F8C2B6A34A"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-6E9916FE-B33F-4C7A-9610-375CC409174C"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-C91578A7-92CD-499D-90E6-E0191D901117"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-02681853-6CB5-4AE9-A70F-A78481E810D7"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-4645D297-467B-4890-911B-8D0EC3F2B278"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-BE5B346B-B000-4E3E-B62F-44A894D5702A"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-6642CDEE-0E87-4F00-97EB-172142534EC2"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-B123F8BB-8808-496A-90B1-3615B65892F5"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-811F2480-7251-4DCD-A6A9-E39250343918"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-7300CAB7-755C-4BA8-ACAB-73363360BF16"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-9DF33938-15BC-46FC-9267-DE4F39008179"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-CEEAB121-661E-4D45-8C14-FB9984597D5B"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-68F5BF84-C3A4-4172-AB90-6C02A72E8C43"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-9D3C4D06-2DB0-4C59-A96B-2447E0358049"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-47BA3D85-3596-4882-AD11-D4A5EC0060C3"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-215FF8C3-F438-4D4C-B36A-5978CC643EA8"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-AE577BE7-4280-464F-9AA4-2BA0869A8417"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-A1E83117-E62E-4C05-8FE3-048260E13952"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-ABFC8EB2-5D45-46E7-8EE7-68CB1A865329"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-F9AB552E-D00A-4C90-9E3B-56E450E81DA1"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-9AFAFDC5-4A79-4F0E-9149-D39EB1F7EBFE"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-EE42571A-5155-44AB-8696-6DA751B914C7"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-80070D12-4D58-47B0-8573-04241DD4EFE7"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-15DCC9FB-C7E7-42AB-A1EC-34046759D782"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-0578B475-4E6F-403F-A86E-39BB4CDB0723"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-6C0E4867-CFB7-4305-82CE-0F15C6B4E0B1"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-C0F7DA33-A85E-434D-97EC-DEB84D8B8C2A"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-432AA2EF-FE57-4918-9332-0FD3D9F34A22"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-0E9337E2-CD1F-4B58-BF38-019B47CB4242"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-9CAB9180-F2B6-4D2C-9993-B828759B5F5A"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-C0677708-6892-4C44-86E6-F4E2FC587294"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-8B1C7392-FC02-40BA-A5B8-F111237AC41F"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-392CBCF8-931F-4F50-AF66-2A347BA1C0AA"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-130166B4-75CC-4228-B9A4-FA6E88216524"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-9B46E08B-D325-43B3-9F10-280199260202"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-2B6DFD52-1AF4-4863-8B7D-6B2325C4E78E"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-A28CD21A-1FB7-466D-A703-41077EACEC65"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-F66ED9E9-50DF-4070-9447-2F385C50D843"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-9738793E-D090-4400-A7F0-CF9D0F30CD8E"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-04C51A82-FD4C-4CCC-B984-5D621EC7DE7E"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-AF63A390-D509-4495-88B5-0088F361DCB0"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-EAC88ED0-4A7A-48F5-B9E1-11C6107B29A7"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-7EBB27C7-26BE-4854-9232-160B588CAED8"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-810C03A6-0B33-4CDB-BAEB-49CE6F941C29"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-895C1626-FE8D-4F83-B86C-27FF41B70A8E"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-5B7EB6CD-CFB2-4CEB-9AEA-BE7F543AA57C"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-C1DDC1D4-A6CC-4119-A7C7-23F46D9DAED2"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-97533F02-D27B-424A-A6CA-C62299D754B0"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-C8AECD56-301B-4601-9A15-367AF567278D"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-2139A2EF-2C00-4AD3-A6A7-E7E4DFC2AC32"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-F6AE3381-D343-4075-A58E-9C82AB065826"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-BC17C33C-096E-4F78-A28E-CDB446C49C5E"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-97797030-1F0F-48A5-96C3-A3C684A14EE6"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-FF1EE972-4AF1-4F73-8367-EC0BB9AE88C2"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-AC062299-AE53-40EE-9453-F9C0C14103F8"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-FBC01EA8-19FC-4FCE-A30E-AE57AFC72DC4"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-99BA3A7D-1A93-446B-A7BB-FFD27BD05096"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-479FE768-2F7B-47BB-867C-5ED11269833F"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-B2E65F11-2261-4F66-BAD7-56A6DE58B711"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-619E51F5-3EA1-4877-9789-0157D8EAB29A"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-3BB4D412-5B8D-4B4F-B286-653EFC3D5526"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-5E40CEE3-4A5D-4402-839A-538D5EDE14B0"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-8B5C4217-17F8-475A-9D99-9B7C788635B0"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-BDC41EA1-7255-4B4A-8617-632FDD735BAB"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-B7439F8C-D61B-47A3-8594-CB2C9F92F8FF"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-EC5F5EFA-AD75-43E4-90F7-4D4FED0991B1"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-0B67FC9F-77D3-4CC0-9C92-61C5DA4B35F8"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-8E1E89CB-353F-4AEF-98FE-601E28472B66"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-4D4849DC-30C2-46CF-A94E-0D5D9A994704"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-BD0E9391-E538-42DF-B31D-9299C9F0D059"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-E84079FA-BC10-45AE-8BEE-1E6244AD1E9E"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-4EC2F347-1850-4D07-B52C-7C90655D482C"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-80BFD73C-BD87-4443-B532-430687AB963C"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-4C9B9838-230B-4EE7-AE44-EC81E0612013"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-788F6355-5A8B-46FA-8151-919C9E9096F3"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-708615AD-25E9-48CA-AF7D-B73C5C46F75A"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-F4CC64E3-788D-4B42-BC11-7288B1701ED9"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-813197A9-BF1A-4D2A-9D0F-5D4265961415"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-81A892B6-FC7D-476D-A239-6108F53A5AE3"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-010434F8-EFDF-4D18-B721-9F272C8E3F80"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-8F78CA70-7478-4516-AF73-ACCB106C0C63"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-4A455878-C333-4D6B-8FA6-C70DC2193E2C"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-B9F9E89E-D95D-4179-B6BB-7581C83FB41C"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-91D05FE1-0A3D-42C0-BC79-F445A4ED2C71"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-72E987BE-7725-4392-9CE0-2C2848FA995C"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-B7554126-056B-4E6E-BC61-7B3E3EF73068"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-C1D0B2AA-96DC-4071-942D-B836B95EC3B6"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-ADC3CCD9-D9C1-462F-965D-EAF6476C1C80"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-AD37796F-ACBA-47B3-888C-5A613E453A9B"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-082D6A5E-928A-416D-8904-0BB7D848B0B4"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-7A9C160C-3A73-446E-834D-96855D324CB6"
    },
    {
      "dependentPackageInstanceGuid": "PCKGINST-1E0F375F-9E4A-4D88-952A-BF1C203C5C40"
    }
  ],
  "ALM_PACKAGE_INSTANCE": {
    "title": "24.07.01",
    "qualityStatus": "QM",
    "guid": "PCKGINST-F236AD64-78FB-4F85-8587-9297A04979EF"
  },
  "timestamp": "2020-04-03T13:41:13.980Z",
  "ALM_PRODUCT": {
    "title": "MSR4_Product",
    "userProperties": {
      "Component.TargetQualityProcess": "Process3"
    },
    "guid": "PCKGBASE-4D3705E6-D3E2-42AC-A398-48F0852B9FEB"
  }
}')
;