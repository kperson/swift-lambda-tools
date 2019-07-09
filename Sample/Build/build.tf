module "build" {
  source = "github.com/kperson/swift-lambda-tools//terraform/swift-build"
  working_dir = "../"
  executable_location = "TODO"
}
