@description('Specifies the location for resources.')
param location string = 'northeurope'
param siteName string = 'WebAppPoCjm'

param digitalTwinsInstances_name string
param eh_namespaces_name string
param serverfarms_name string

var sanitizedSiteName = toLower(replace(siteName, ' ', ''))

resource digitalTwinsInstancesdt_name_resource 'Microsoft.DigitalTwins/digitalTwinsInstances@2020-12-01' = {
  location: location
  name: digitalTwinsInstances_name
  properties: {
    privateEndpointConnections: []
    publicNetworkAccess: 'Enabled'
  }
}

resource namespaces_name_resource 'Microsoft.EventHub/namespaces@2021-11-01' = {
  location: location
  name: eh_namespaces_name
  sku: {
    capacity: 1
    name: 'Basic'
    tier: 'Basic'
  }
}


resource serverfarms_name_resource 'Microsoft.Web/serverfarms@2021-02-01' = {
  kind: 'functionapp'
  location: location
  name: serverfarms_name
  sku: {
    capacity: 0
    family: 'Y'
    name: 'Y1'
    size: 'Y1'
    tier: 'Dynamic'
  }
}


resource namespaces_name_RootManageSharedAccessKey 'Microsoft.EventHub/namespaces/AuthorizationRules@2021-11-01' = {
  parent: namespaces_name_resource
  name: 'RootManageSharedAccessKey'
  properties: {
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
}

resource namespaces_name_namespaces_name_eh 'Microsoft.EventHub/namespaces/eventhubs@2021-11-01' = {
  parent: namespaces_name_resource
  name: '${eh_namespaces_name}eh'
  properties: {
    messageRetentionInDays: 1
    partitionCount: 2
    status: 'Active'
  }
}

resource namespaces_name_default 'Microsoft.EventHub/namespaces/networkRuleSets@2021-11-01' = {
  parent: namespaces_name_resource
  name: 'default'
  properties: {
    defaultAction: 'Allow'
    ipRules: []
    publicNetworkAccess: 'Enabled'
    virtualNetworkRules: []
  }
}



resource site_resource 'Microsoft.Web/sites@2021-02-01' = {
  identity: {
    type: 'SystemAssigned'
  }
  location: location
  kind: 'functionapp'
  name: sanitizedSiteName
}

resource site_web 'Microsoft.Web/sites/config@2021-02-01' = {
  parent: site_resource
  name: 'web'
}

resource site_IoTHubToTwins 'Microsoft.Web/sites/functions@2021-02-01' = {
  parent: site_resource
  name: 'IoTHubToTwins'
  properties: {
    config: {}
    isDisabled: false
    language: 'DotNetAssembly'
  }
}

resource site_site_azurewebsites_net 'Microsoft.Web/sites/hostNameBindings@2021-02-01' = {
  parent: site_resource
  name: '${sanitizedSiteName}.azurewebsites.net'
  properties: {
    hostNameType: 'Verified'
    siteName: siteName
  }
}

resource namespaces_name_namespaces_name_eh_iotcentral 'Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2021-11-01' = {
  parent: namespaces_name_namespaces_name_eh
  name: 'iotcentral'
  properties: {
    rights: [
      'Listen'
      'Send'
    ]
  }
  dependsOn: [
  ]
}

resource namespaces_name_namespaces_name_eh_Default 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2021-11-01' = {
  parent: namespaces_name_namespaces_name_eh
  name: '$Default'
  properties: {}
  dependsOn: [
  ]
}
