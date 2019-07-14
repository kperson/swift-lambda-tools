locals {
  env = {
    PET_TABLE = "${data.template_file.dynamo_pet_table_id.rendered}"
    PET_QUEUE_URL = "${data.template_file.sqs_pet_id.rendered}"
  }
}
