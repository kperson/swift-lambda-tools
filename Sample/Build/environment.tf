locals {
  env = {
    PET_TABLE     = "${module.dynamo_pet.id}"
    PET_QUEUE_URL = "${aws_sqs_queue.pet.id}"
    PET_TOPIC_ARN = "${aws_sns_topic.pet.arn}"
    LOG_LEVEL     = "WARN"
  }
}
