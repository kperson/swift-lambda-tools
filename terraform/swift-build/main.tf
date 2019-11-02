variable "working_dir" {
  type = "string"
}

variable "executable_location" {
  type = "string"
}

variable "docker_file" {
  type    = "string"
  default = "NA"
}

variable "dind_mount" {
  type    = "string"
  default = ""
}

resource "random_string" "tag" {
  length  = 15
  upper   = false
  number  = false
  special = false
  keepers = {
    time = timestamp()
  }
}

data "template_file" "build_script" {
  template = "${file("${path.module}/image_build_push_script.tpl")}"

  vars = {
    tag         = random_string.tag.result
    docker_file = "${var.docker_file == "NA" ? "Build/${path.module}/Dockerfile" : var.docker_file}"
  }
}

resource "null_resource" "docker_build" {
  triggers = {
    time = "${timestamp()}"
  }

  provisioner "local-exec" {
    working_dir = var.working_dir
    command     = data.template_file.build_script.rendered

    environment = {
    }
  }
}

data "template_file" "docker_tag" {
  depends_on = ["null_resource.docker_build"]
  template   = "$${output_file}"

  vars = {
    output_file = random_string.tag.result
  }
}

output "docker_tag" {
  value = data.template_file.docker_tag.rendered
}


data "template_file" "extract_script" {
  template = "${file("${path.module}/extract_script.tpl")}"

  vars = {
    dind_mount     = var.dind_mount
    container_file = var.executable_location
    tag            = random_string.tag.result
    output_file    = "swiftApp"
    working_dir    = path.cwd
    bootstrap_file = "${path.module}/bootstrap"
  }
}

resource "null_resource" "docker_extract" {
  depends_on = ["null_resource.docker_build"]

  triggers = {
    time = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = data.template_file.extract_script.rendered

    environment = {
    }
  }
}

data "archive_file" "zip" {
  depends_on  = ["null_resource.docker_extract"]
  type        = "zip"
  source_dir  = random_string.tag.result
  output_path = "${random_string.tag.result}.zip"
}

output "zip_file" {
  value = "${random_string.tag.result}.zip"
}

output "zip_file_hash" {
  value = data.archive_file.zip.output_base64sha256
}

resource "null_resource" "cleanup_dir" {

  triggers = {
    time = timestamp()
  }
  provisioner "local-exec" {
    command = "rm -rf ${random_string.tag.result}"

    environment = {
      ZIP_FILE_HASH = data.archive_file.zip.output_base64sha256
    }
  }
  
}
