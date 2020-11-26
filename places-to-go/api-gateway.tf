resource "aws_api_gateway_rest_api" "places_to_go" {
  name        = "places_to_go"
  description = "API for places play thing"
}





resource "aws_api_gateway_deployment" "live" {

  rest_api_id = "${aws_api_gateway_rest_api.places_to_go.id}"
  stage_name  = "live"
}