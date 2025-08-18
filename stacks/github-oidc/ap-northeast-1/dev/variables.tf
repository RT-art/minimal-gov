variable "env"       { type = string }
variable "app_name"  { type = string }
variable "region"    { type = string }
variable "repo"      { type = string } 
variable "branches" {
  type    = list(string)
  default = ["main"]
}
