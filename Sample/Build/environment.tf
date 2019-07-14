locals {
  env = {
    PET_TABLE = "${data.template_file.dynamo_pet_table_id.rendered}"
  }
}
