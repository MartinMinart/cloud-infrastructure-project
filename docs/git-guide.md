# Git — руководство по проекту

## 📦 Один раз: настройка

```powershell
cd C:\Users\MI\Desktop\cloud-infrastructure-project
git init
git branch -M main
git remote add origin https://github.com/MartinMinart/cloud-infrastructure-project.git
```

## 🔍 Перед каждым коммитом

```powershell
# 1. Проверить, что .gitignore работает
git status

# 2. Проверить, что пароли не попали
git diff --cached | Select-String 'pass_2024|admin123|YWRtaW4'
```

## ✅ Коммит

```powershell
git add .
git status                    # проверить список файлов
git commit -m "Initial commit: cloud infrastructure project"
```

## 🚀 Push

```powershell
git push -u origin main
```

## 🔄 Обновления

```powershell
git add <файл>
git commit -m "Update README"
git push
```

## 🚨 Если что-то не так

| Проблема | Решение |
|---|---|
| Файл попал в staged по ошибке | `git reset HEAD <файл>` |
| Отменить последний коммит | `git reset --soft HEAD~1` |
| Посмотреть remote | `git remote -v` |
| Сменить remote | `git remote set-url origin <new-url>` |
| Игнорировать изменения файла | `git update-index --skip-worktree <файл>` |

## ⚠️ НИКОГДА

- ❌ `git add .` без `git status`
- ❌ `git commit -m "fix"` без описания
- ❌ `git push --force` в main
- ❌ `rm -rf .git` без бэкапа
```