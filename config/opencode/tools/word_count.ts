import { tool } from "@opencode-ai/plugin"
import path from "path"

export default tool({
  description: "テキストの行数・単語数・文字数をカウントする",
  args: {
    text: tool.schema.string().describe("カウント対象のテキスト"),
  },
  async execute(args, context) {
    const script = path.join(import.meta.dir, "word_count.py")
    const result = await Bun.$`python3 ${script} ${args.text}`.text()
    return result.trim()
  },
})
