hitCounter = softwareSystem "Hit Counter" {
    description "..."
    !include ./hit-counter/hit-counter.dsl
}

thirdPartyWebsite = softwareSystem "Third-Party Website"
thirdPartyWebsite -> hitCounter.writeApi "Sends visit statistics"
authProviders = softwareSystem "Auth Providers" "Facebook, Google, Linkedin, etc..."

urlShortener = softwareSystem "URL Shortener" {
    description "Creates an alias with shorter length. If you click the alias, it redirects you to the original URL."
    !include ./url-shortener/url-shortener.dsl
}

user = person "User"
user -> urlShortener.web "SignUp/SignIn, Creates short URL" "HTTPS"
user -> urlShortener.readApi.urlController "Visits a short url" "HTTPS"
user -> thirdPartyWebsite "Is redirected to" "HTTPS 302"

analyst = person "Analyst"
analyst -> hitCounter.spa "Sees the reports"