#more details and credits to: https://github.com/swagger-api/swagger-codegen/tree/master

# get swagger generator
#wget https://repo1.maven.org/maven2/io/swagger/swagger-codegen-cli/2.4.31/swagger-codegen-cli-2.4.31.jar -O swagger-codegen-cli.jar

# download swagger schema
Invoke-WebRequest -Uri https://petstore.swagger.io/v2/swagger.yaml -o swagger.yaml

# generate ps code
java -jar swagger-codegen-cli.jar generate -i .\swagger.yaml -l powershell -o petstore/powershell

# try to import
import-Module .\petstore\powershell\src\IO.Swagger\\IO.Swagger.psm1

#generate csharp code
java -jar swagger-codegen-cli.jar generate -i .\swagger.yaml -l csharp -o petstore/powershell/csharp/SwaggerClient

# build ps module
./petstore/powershell/Build.ps1

# Import module
cd  .\petstore\powershell\src\IO.Swagger
import-Module .\IO.Swagger.psd1 -Force

# list cmdlets
Get-Command -module IO.Swagger

# get help
Get-Help Invoke-StoreApiPlaceOrder -Full

# place order
$order = New-Order -id 1 -petId 125 -quantity 1 -shipDate (Get-Date) -status “approved” -complete $true
Invoke-StoreApiPlaceOrder -body $order


# Try again with mustache templates: 
cd ../../../../

# TODO: get mustache templates from 
# https://github.com/swagger-api/swagger-codegen/tree/master/modules/swagger-codegen/src/main/resources/powershell

# TODO: update api.mustache with your preferences

# regenerate with templates
java -jar swagger-codegen-cli.jar generate -i .\swagger.yaml -l powershell -o petstore/powershell -t .\mustache
./petstore/powershell/Build.ps1

# Import module
cd  .\petstore\powershell\src\IO.Swagger
import-Module .\IO.Swagger.psd1 -Force
Get-Command -module IO.Swagger