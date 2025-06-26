<template>
  <div class="h-100 d-flex align-center justify-md-space-between justify-center">
    <!-- 👉 Footer: left content -->
    <span class="d-flex align-center">
      &copy;
      {{ new Date().getFullYear() }}
      Team Task Manager - チームタスク管理システム
    </span>
    <!-- 👉 Footer: right content -->
    <span class="d-md-flex gap-x-4 text-primary d-none">
      <a
        href="/dashboard"
        target="_self"
      >ダッシュボード</a>
      <a
        href="/tasks"
        target="_self"
      >タスク</a>
      <a
        href="/work-groups"
        target="_self"
      >ワークグループ</a>
      <a
        href="/profile"
        target="_self"
      >プロフィール</a>
    </span>
  </div>
</template>
