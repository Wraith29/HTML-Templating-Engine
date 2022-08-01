import tables
import ./templater

type Post = object
  id: int
  title, body: string

func newPost(id: int, title, body: string): Post =
  Post(id: id, title: title, body: body)

proc newType(post: Post): VarType =
  newType({
    "id": post.id.newType,
    "title": post.title.newType,
    "body": post.body.newType
  }.toTable)

proc main() =
  let code = readFile("test2.html")
  let posts = @[
    newPost(1, "Title 1", "Body 1").newType,
    newPost(2, "Title 2", "Body 2").newType,
    newPost(3, "Title 3", "Body 3").newType
  ]
  let vars = {
    "docTitle": "Top Bar".newType,
    "pageTitle": "Posts".newType,
    "posts": posts.newType
  }.toTable

  writeFile("examples/two.html", parseTemplate(code, vars))

when isMainModule:
  main()