import { tool } from "@opencode-ai/plugin"

// git log を指定件数取得してまとめて返すツール
export default tool({
  description:
    "指定した件数の git コミットログを取得する。コミット履歴の確認や変更内容の把握に使う。",
  args: {
    count: tool.schema
      .number()
      .describe("取得するコミット件数（デフォルト: 10）")
      .optional(),
    branch: tool.schema
      .string()
      .describe("対象ブランチ名（省略時は現在のブランチ）")
      .optional(),
  },
  async execute(args, context) {
    const count = args.count ?? 10
    const branch = args.branch ?? "HEAD"
    const { $ } = await import("bun")

    const result =
      await $`git -C ${context.worktree} log ${branch} -${count} --pretty=format:"%h %as %s" --no-merges`.text()

    return result.trim() || "コミットが見つかりませんでした。"
  },
})
