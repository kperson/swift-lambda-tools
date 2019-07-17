locals {
  env = {
    PET_TABLE     = "${aws_dynamodb_table.pet.id}"
    PET_QUEUE_URL = "${aws_sqs_queue.pet.id}"
  }
}
