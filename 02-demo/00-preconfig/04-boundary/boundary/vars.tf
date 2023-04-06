variable "addr" {
  default = "http://127.0.0.1:9200"
}

variable "users" {
  type = set(string)
  default = [    
    "group0",   
    "group1",   
    "group2",   
    "group3",   
    "group4",   
    "group5",   
    "group6",   
    "group7",   
    "group8",   
    "group9", 
    "group10",   
    "group11",   
    "group12",   
    "group13",   
    "group14",   
    "group15",   
    "group16",   
    "group17",   
    "group18",   
    "group19",
  ]
}

variable "admins" {
  type = set(string)
  default = [
    "admin0",
    "admin1",
    "admin2",
  ]
}
