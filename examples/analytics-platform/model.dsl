system = softwareSystem "System" "A system that does something." {
}

person = person "Person" "A person that does something." 
person --https-> system "Uses the system to do something."