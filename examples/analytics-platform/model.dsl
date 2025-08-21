system = softwareSystem "Analytics Platform" "" {
    !adrs adrs
    !docs docs/src
}

person = person "Person" "A person that does something." 
person --https-> system "Uses the system to do something."