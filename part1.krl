ruleset echo {
  rule hello {
    select when echo hello
    send_directive("say") with
      something = "Hello World";
  }
  rule message {
    select when echo message input "(.*)" setting(m)
    send_directive("say") with
      something = m
  }
}
