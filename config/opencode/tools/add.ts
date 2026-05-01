import { tool } from "@opencode-ai/plugin"
import path from "path"

export default tool({
  description: "2つの数値を足し算する",
  args: {
    a: tool.schema.number().describe("1つ目の数値"),
    b: tool.schema.number().describe("2つ目の数値"),
  },
  async execute(args, context) {
    const script = path.join(import.meta.dir, "add.py")
    const result = await Bun.$`python3 ${script} ${args.a} ${args.b}`.text()
    return result.trim()
  },
})
