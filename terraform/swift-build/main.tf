variable "working_dir" {
  type = string
}

variable "executable_location" {
  type = string
}

variable "docker_file" {
  type    = string
  default = "NA"
}

variable "dind_mount" {
  type    = string
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


resource "null_resource" "docker_build" {
  triggers = {
    time = timestamp()
  }

  provisioner "local-exec" {
    working_dir = var.working_dir
    command = templatefile(format("%s/image_build_push_script.tpl", path.module), {
      tag         = random_string.tag.result,
      docker_file = var.docker_file == "NA" ? format("Build/%s/Dockerfile", path.module) : var.docker_file
    })

    environment = {
    }
  }
}

output "docker_tag" {
  depends_on = [null_resource.docker_build]
  value = random_string.tag.result
}

resource "null_resource" "docker_extract" {
  depends_on = [null_resource.docker_build]

  triggers = {
    time = timestamp()
  }

  provisioner "local-exec" {
    command = templatefile(format("%s/extract_script.tpl", path.module), {
      dind_mount     = var.dind_mount,
      container_file = var.executable_location,
      tag            = random_string.tag.result,
      output_file    = "swiftApp",
      working_dir    = path.cwd,
      bootstrap_file = format("%s/bootstrap", path.module)
    })

    environment = {
    }
  }
}

data "archive_file" "zip" {
  depends_on  = [null_resource.docker_extract]
  type        = "zip"
  source_dir  = random_string.tag.result
  output_path = format("%s.zip", random_string.tag.result)
}

output "zip_file" {
  value = format("%s.zip", random_string.tag.result)
}

output "zip_file_hash" {
  value = data.archive_file.zip.output_base64sha256
}

resource "null_resource" "cleanup_dir" {

  triggers = {
    time = timestamp()
  }
  provisioner "local-exec" {
    command = format("rm -rf %s", random_string.tag.result)
    environment = {
      ZIP_FILE_HASH = data.archive_file.zip.output_base64sha256
    }
  }

}
