import tables
import ./templater

type Post = object
  title, body: string

func newPost(title, body: string): Post =
  Post(title: title, body: body)

proc newType(post: Post): VarType =
  newType({
    "title": post.title.newType,
    "body": post.body.newType
  }.toTable)

proc main() =
  let code = readFile("test.html")
  let posts = @[
    newPost("Title 1", "Body 1").newType,
    newPost("Title 2", "Body 2").newType,
    newPost("Title 3", "Body 3").newType
  ]
  let vars = {
    "docTitle": "Top Bar".newType,
    "pageTitle": "Posts".newType,
    "posts": posts.newType
  }.toTable

  writeFile("examples/one.html", parseTemplate(code, vars))

when isMainModule:
  main()