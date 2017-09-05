# Script to run when config.xml is updated to set the azure-role-name and azure-role-instance-id
# values.
param($agentConfigFile, $azureRoleName, $azureRoleInstanceId)

$config = New-Object System.Xml.XmlDocument
$config.Load($agentConfigFile)

$appAgentsNode = $config.SelectSingleNode("/appdynamics-agent/app-agents")

$appAgentsNode.SetAttribute('azure-role-name', $azureRoleName)
$appAgentsNode.SetAttribute('azure-role-instance-id', $azureRoleInstanceId)

$config.Save($agentConfigFile)
