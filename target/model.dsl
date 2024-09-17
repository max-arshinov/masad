hitCounter = softwareSystem "Hit Counter" {
    description "..."
    !include ./hit-counter/hit-counter.dsl
}

anotherWebsite = softwareSystem "Another Website"
authProviders = softwareSystem "Auth Providers" "Facebook, Google, Linkedin, etc..."

urlShortener = softwareSystem "URL Shortener" {
    description "Creates an alias with shorter length. If you click the alias, it redirects you to the original URL."
    !include ./url-shortener/url-shortener.dsl
}

user = person "User"
user -> urlShortener.web "SignUp/SignIn, Creates short URL" "HTTPS"
user -> urlShortener.readApi "Visits a short url" "HTTPS"
user -> anotherWebsite "Redirected to" "HTTPS"

