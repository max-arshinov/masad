group "services" {
application = softwaresystem "Where is Fluffy?"
registration = softwaresystem "Registration of Users" "Register all the users, pet owners,pet finders,general public"
application -> registration "register yourself"
generalPost = softwaresystem "Have You Lost/Find Pet ?" "Post the photo and location of Fluffy" "Pet owner, Pet Finder"
application -> generalPost "Asks questions to" "Telephone"
}

ownerPost = person "Pet Owner Post" "Whether your pet is missing ?"
generalPost -> ownerPost "Post"

group "Communicate" {
    email = person "E-Mail" "Allows pet finders and pet owners to communicate"
    email -> ownerPost "Sends e-mails to"

    Phone = person "Phone" "Allows pet finders and pet owners to communicate"
    ownerPost -> Phone "communicate using"
}