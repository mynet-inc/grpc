#! /bin/bash

current_dir=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

if [ -z $1 ]
then
  echo "usage: build_grpc_cshap_ext.sh output_dir build_type(debug or release)"
  exit 1
fi

if [ -z $2 ]
then
  echo "usage: build_grpc_cshap_ext.sh output_dir build_type(debug or release)"
  exit 1
fi

OUTPUT_DIR=$(cd $1 && pwd)
BUILD_TYPE=$2

# Android
if [ -z "$ANDROID_NDK" ]
then
  echo 'You must set Android NDK Path to $ANDROID_NDK.'
  echo 'ex. export ANDROID_NDK=/Path/To/NDK'
  exit 1
fi

# Android arm-v7a
target=arm-v7a
abi=armeabi-v7a
work_dir="build_$target"

cd "$current_dir/vsprojects/grpc_csharp_ext_android"
rm -dfr "$work_dir"
mkdir "$work_dir"
cd "$work_dir"

cmake -DANDROID_ABI=$abi -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DCMAKE_TOOLCHAIN_FILE=../../../third_party/android-cmake/android.toolchain.cmake -DANDROID_NATIVE_API_LEVEL=19 -GNinja ..

ninja

rm -dfr "$OUTPUT_DIR/Android/$target"
mkdir -p "$OUTPUT_DIR/Android/$target"
cp ./libgrpc_csharp_ext.so "$OUTPUT_DIR/Android/$target/"

# Android x86
target=x86
abi=x86
work_dir="build_$target"

cd "$current_dir/vsprojects/grpc_csharp_ext_android"
rm -dfr "$work_dir"
mkdir "$work_dir"
cd "$work_dir"

cmake -DANDROID_ABI=$abi -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DCMAKE_TOOLCHAIN_FILE=../../../third_party/android-cmake/android.toolchain.cmake -DANDROID_NATIVE_API_LEVEL=19 -GNinja ..

ninja

rm -dfr "$OUTPUT_DIR/Android/$target"
mkdir -p "$OUTPUT_DIR/Android/$target"
cp ./libgrpc_csharp_ext.so "$OUTPUT_DIR/Android/$target/"

# iOS
work_dir="build"

cd "$current_dir/xcprojects/grpc_csharp_ext_ios"
rm -dfr "$work_dir"
mkdir -p "$work_dir"

xcodebuild -workspace grpc_csharp_ext.xcworkspace -scheme grpc_csharp_ext -configuration $BUILD_TYPE -derivedDataPath "$work_dir" clean build

rm -dfr "$OUTPUT_DIR/iOS"
mkdir -p "$OUTPUT_DIR/iOS"
cp "$work_dir/Build/Products/Release-iphoneos/libgrpc_csharp_ext.a" "$OUTPUT_DIR/iOS/"
cp "$work_dir/Build/Products/Release-iphoneos/gRPC-Core/libgRPC-Core.a" "$OUTPUT_DIR/iOS/"
cp "$work_dir/Build/Products/Release-iphoneos/BoringSSL/libBoringSSL.a" "$OUTPUT_DIR/iOS/"
