targetSystem = softwareSystem "Taget System" "A system that does something." {
    !docs ./docs/src
    !adrs ./adrs
}

targetPerson = person "Person" "A person that does something." 
targetPerson --https-> targetSystem "Uses the system to do something."