import { tool } from "@opencode-ai/plugin"

// ファイルの行数・サイズ・拡張子ごとの統計を返すツール
export default tool({
  description:
    "指定ディレクトリ内のファイル統計（拡張子ごとのファイル数・総行数）を返す。コードベースの規模把握に使う。",
  args: {
    directory: tool.schema
      .string()
      .describe(
        "集計対象のディレクトリパス（省略時はプロジェクトルート）"
      )
      .optional(),
    extensions: tool.schema
      .string()
      .describe(
        "対象拡張子をカンマ区切りで指定（例: ts,tsx,js）。省略時は全ファイル"
      )
      .optional(),
  },
  async execute(args, context) {
    const { $ } = await import("bun")
    const dir = args.directory
      ? `${context.worktree}/${args.directory}`
      : context.worktree

    const extFilter = args.extensions
      ? args.extensions
          .split(",")
          .map((e) => e.trim())
          .filter(Boolean)
      : []

    // 対象ファイルを列挙
    const findArgs = ["find", dir, "-type", "f", "-not", "-path", "*/.git/*"]
    if (extFilter.length > 0) {
      findArgs.push("(")
      extFilter.forEach((ext, i) => {
        if (i > 0) findArgs.push("-o")
        findArgs.push("-name", `*.${ext}`)
      })
      findArgs.push(")")
    }

    const files =
      await $`${findArgs}`.text().then((t) =>
        t
          .trim()
          .split("\n")
          .filter(Boolean)
      )

    if (files.length === 0) {
      return "対象ファイルが見つかりませんでした。"
    }

    // 拡張子ごとに集計
    const stats: Record<string, { count: number; lines: number }> = {}
    for (const file of files) {
      const ext = file.includes(".") ? file.split(".").pop()! : "(no ext)"
      if (!stats[ext]) stats[ext] = { count: 0, lines: 0 }
      stats[ext].count++
      const lineCount =
        await $`wc -l < ${file}`.text().then((t) => parseInt(t.trim()) || 0)
      stats[ext].lines += lineCount
    }

    const totalFiles = Object.values(stats).reduce((s, v) => s + v.count, 0)
    const totalLines = Object.values(stats).reduce((s, v) => s + v.lines, 0)

    const rows = Object.entries(stats)
      .sort((a, b) => b[1].lines - a[1].lines)
      .map(([ext, v]) => `  .${ext}: ${v.count} files, ${v.lines} lines`)
      .join("\n")

    return `合計: ${totalFiles} files, ${totalLines} lines\n\n拡張子別:\n${rows}`
  },
})
