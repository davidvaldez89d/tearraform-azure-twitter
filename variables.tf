variable "dave_tags" {
  type = map(string)
  description = "My Dictionary of tags for azure resources"
  default = {
    "contact" = "davidvaldez89d@gmail.com"
    "promo_type" = "ai"
    "promo_name" = "bouman5"
  }
  sensitive = false
}

