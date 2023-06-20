#!/bin/sh

# Used to clean up the tmp directories used to overlay dotnet sdk directory when not using bootstrap

HOME=$(mktemp -d)

# Copy SourceLink files to .git directory.  This essentially does the same thing that pack-sources.sh does
mkdir .git/
cp -r debian/SourceLink/* .git/

if [ "$1" = "--bootstrap" ]
then
    ./prep.sh
    ./build.sh --clean-while-building -- /p:SkipPortableRuntimeBuild=true
else
    # Copy installed SDK locally, as the build script will attempt to modify the SDK during build.
    # After copy, it might be necessary to change owner of all files.
    cp -r "/usr/lib/${DEB_HOST_MULTIARCH}/dotnet/" .dotnet/

    # Link to previously source built artifacts 
    ln -s  /usr/lib/${DEB_HOST_MULTIARCH}/dotnet/source-built-artifacts/Private.SourceBuilt.*-x64.tar.gz ./prereqs/packages/archive/

    ./build.sh --clean-while-building --with-sdk .dotnet -- /p:SkipPortableRuntimeBuild=true
fi
