#!/usr/bin/env -S bash -e
function open_messages {
    message "\n\nCheck application at https://$LOCAL_DEFAULT_DOMAIN/\n"
    message "\n\nCheck ao at https://$LOCAL_API_DEFAULT_DOMAIN/\n"
}

function open_do {
    message "\nOpening browser https://$LOCAL_DEFAULT_DOMAIN/ ...\n"
    openBrowser "https://$LOCAL_DEFAULT_DOMAIN/"
}

