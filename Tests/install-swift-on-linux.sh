#! /bin/sh

set -euv

DISTRIBUTION=`lsb_release -i | sed -e 's/^.*:[[:space:]]*//' | tr 'A-Z' 'a-z'`
DISTRIBUTION_VERSION=`lsb_release -r | sed -e 's/^.*:[[:space:]]*//'`
DISTRIBUTION_MAJOR_VERSION=`echo $DISTRIBUTION_VERSION | cut -d. -f 1`
DISTRIBUTION_MINOR_VERSION=`echo $DISTRIBUTION_VERSION | cut -d. -f 2`
SWIFT="swift-${SWIFT_VERSION}-RELEASE-${DISTRIBUTION}${DISTRIBUTION_MAJOR_VERSION}.${DISTRIBUTION_MINOR_VERSION}"
SWIFT_PACKAGE="${SWIFT}.tar.gz"
URL="https://swift.org/builds/swift-${SWIFT_VERSION}-release/${DISTRIBUTION}${DISTRIBUTION_MAJOR_VERSION}${DISTRIBUTION_MINOR_VERSION}/swift-${SWIFT_VERSION}-RELEASE/${SWIFT_PACKAGE}"

wget "${URL}"
tar xf "${SWIFT_PACKAGE}"

readlink -f ${SWIFT}/usr/bin
