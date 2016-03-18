ruleset echo is active{
  rule hello {
    select when echo hello
    send_directive("say") with
      something = "Hello World";
  }
  rule message is active{
    select when echo message input "(.*)" setting(m)
    send_directive("say") with
      something = m
  }
}
