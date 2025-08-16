us = softwareSystem "Url Shortener" "..." {
    !include us.dsl
}

user = person "User" "A person that clicks on short urls."
creator = person "Link Creator " "..." 
user --https-> us "."