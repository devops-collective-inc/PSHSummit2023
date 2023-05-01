# project.build.ps1
param(
	[ValidateSet('Debug', 'Release')]
	[string]$Configuration = 'Release'
)

# The default build
task . restore, build

task restore {
	exec { dotnet restore }
}

task build {
	exec { dotnet build -c $Configuration }
}

task clean {
	remove bin, obj
}

