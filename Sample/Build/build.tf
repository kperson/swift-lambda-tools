module "build" {
  #source = "github.com/kperson/swift-lambda-tools//terraform/swift-build"
  source              = "../../terraform/swift-build"
  working_dir         = "../"
  executable_location = "/code/.lambda-build/x86_64-unknown-linux/release/Sample"
}
