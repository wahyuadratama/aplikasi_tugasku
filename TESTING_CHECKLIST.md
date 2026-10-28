# TugasKu - Testing Checklist

## Pre-Installation
- [ ] APK file exists: `build/app/outputs/flutter-apk/app-release.apk` (51 MB)
- [ ] Phone has USB Debugging enabled
- [ ] Phone has "Unknown Sources" permission enabled
- [ ] Phone has at least 100 MB free storage

## Installation
- [ ] APK installed successfully
- [ ] App icon appears on home screen
- [ ] App launches without crashing

## First Launch
- [ ] Splash screen appears
- [ ] Sample tasks load automatically
- [ ] Dark/Light mode works correctly
- [ ] No permission errors

## Core Features Testing

### Task Management
- [ ] **Add Task**: Tap + button, fill form, save
  - [ ] Title is required
  - [ ] Category defaults to "Umum"
  - [ ] Priority defaults to "Sedang"
  - [ ] Deadline is optional
- [ ] **Edit Task**: Tap task card, modify, save
  - [ ] Changes persist
  - [ ] Deadline updates correctly
- [ ] **Delete Task**: Tap delete icon, confirm
  - [ ] Task removed from list
  - [ ] Notification cancelled if had reminder

### Categories & Filtering
- [ ] **Category Chips**: Visible at top of list
  - [ ] "Semua" shows all tasks
  - [ ] Tap category filters tasks
  - [ ] Case-insensitive (Kuliah = kuliah)
- [ ] **Auto-normalize**: Delete last task in category
  - [ ] Filter resets to "Semua"
  - [ ] No empty state shown

### Search Feature ✨ NEW
- [ ] **Search Icon**: Visible in AppBar
- [ ] **Toggle Search**: Tap search icon
  - [ ] TextField appears
  - [ ] Title changes to search field
  - [ ] Clear button appears
- [ ] **Search Functionality**:
  - [ ] Type in search field
  - [ ] Tasks filter in real-time
  - [ ] Searches title and description
  - [ ] Case-insensitive
- [ ] **Clear Search**: Tap clear button
  - [ ] Search field clears
  - [ ] All tasks shown again
  - [ ] Search mode closes

### Sorting
- [ ] **Sort Button**: Visible in AppBar (sort icon)
- [ ] **Sort Options**:
  - [ ] Manual (default)
  - [ ] Deadline (earliest first)
  - [ ] Priority (High → Medium → Low)
  - [ ] Name (A-Z)
- [ ] **Sort Persistence**: Close and reopen app
  - [ ] Selected sort option persists

### Priorities
- [ ] **High Priority**: Red/orange color
- [ ] **Medium Priority**: Yellow/orange color
- [ ] **Low Priority**: Green color
- [ ] **Priority Label**: Shows "Tinggi/Sedang/Rendah"

### Deadlines
- [ ] **Set Deadline**: Add task with future date
  - [ ] Date picker works
  - [ ] Date displays correctly
- [ ] **Deadline Labels**:
  - [ ] Today: "Hari ini"
  - [ ] Tomorrow: "Besok"
  - [ ] Future: "DD Mon" format
  - [ ] Past: "DD/M/YYYY (terlambat)"
- [ ] **Overdue Marking**: Create task with past deadline
  - [ ] Shows "(terlambat)" label
  - [ ] Visual indicator (red color)

### Sub-Tasks
- [ ] **Add Sub-Task**: Edit task, tap "Tambah sub-tugas"
  - [ ] Input field appears
  - [ ] Can add multiple sub-tasks
- [ ] **Toggle Sub-Task**: Tap checkbox on sub-task
  - [ ] Checkbox toggles
  - [ ] Progress bar updates
- [ ] **Delete Sub-Task**: Tap delete icon on sub-task
  - [ ] Sub-task removed
  - [ ] Progress updates
- [ ] **Progress Display**: Task card shows "X/Y" counter
  - [ ] Correct count displayed
  - [ ] Progress bar fills correctly

### Completed Tasks
- [ ] **Mark Complete**: Tap checkbox on task
  - [ ] Task disappears from active list
  - [ ] Notification cancelled
- [ ] **Completed Screen**: Tap check circle icon
  - [ ] Shows completed tasks
  - [ ] Can edit completed tasks
  - [ ] Can mark incomplete (checkbox)
- [ ] **Back to Home**: Tap back
  - [ ] Returns to home screen
  - [ ] Task list refreshes

### Notifications & Reminders
- [ ] **Set Reminder**: Add task with deadline
  - [ ] Reminder toggle appears (if deadline set)
  - [ ] Can enable/disable reminder
- [ ] **Reminder Timing**:
  - [ ] H-1 at 08:00 (if deadline > tomorrow)
  - [ ] Day-of at 08:00 (if deadline today/tomorrow)
- [ ] **Notification Received**: Wait for scheduled time
  - [ ] Notification appears
  - [ ] Title shows task name
  - [ ] Body shows deadline info
- [ ] **Cancel Reminder**: Mark task complete
  - [ ] Notification cancelled
  - [ ] No duplicate notifications

### Theme & Appearance
- [ ] **Light Mode**: Tap theme button → Terang
  - [ ] Background white
  - [ ] Text dark
  - [ ] Colors correct
- [ ] **Dark Mode**: Tap theme button → Gelap
  - [ ] Background dark
  - [ ] Text light
  - [ ] Colors correct
- [ ] **System Mode**: Tap theme button → Ikut sistem
  - [ ] Follows phone theme
  - [ ] Changes when phone theme changes
- [ ] **Theme Persistence**: Close and reopen app
  - [ ] Selected theme persists

### Empty States
- [ ] **No Tasks**: Delete all tasks
  - [ ] Empty state illustration shows
  - [ ] Message: "Belum ada tugas. Tambah lewat tombol + ya!"
- [ ] **No Filtered Results**: Filter by category with no tasks
  - [ ] Empty state illustration shows
  - [ ] Message: "Tidak ada tugas di kategori ini"
- [ ] **No Completed Tasks**: Go to completed screen with no completed tasks
  - [ ] Empty state illustration shows
  - [ ] Message: "Belum ada tugas selesai"

### Animations
- [ ] **Screen Transitions**: Navigate between screens
  - [ ] Smooth slide + fade animation
  - [ ] No jank or stuttering
- [ ] **Task Card Interactions**: Tap, delete, toggle
  - [ ] Smooth animations
  - [ ] Responsive feedback

### Data Persistence
- [ ] **Save Task**: Add task, close app
  - [ ] Reopen app
  - [ ] Task still there
- [ ] **Edit Persistence**: Edit task, close app
  - [ ] Reopen app
  - [ ] Changes persisted
- [ ] **Delete Persistence**: Delete task, close app
  - [ ] Reopen app
  - [ ] Task still deleted
- [ ] **Sort Preference**: Change sort, close app
  - [ ] Reopen app
  - [ ] Sort preference saved
- [ ] **Theme Preference**: Change theme, close app
  - [ ] Reopen app
  - [ ] Theme preference saved

### Performance
- [ ] **App Launch**: Time to first screen < 2 seconds
- [ ] **Task List**: Smooth scrolling with 20+ tasks
- [ ] **Search**: Real-time filtering responsive
- [ ] **Memory**: No crashes with 100+ tasks
- [ ] **Battery**: No excessive battery drain

### Error Handling
- [ ] **Empty Title**: Try to save task without title
  - [ ] Error message shown
  - [ ] Task not saved
- [ ] **Invalid Date**: Try to set invalid deadline
  - [ ] Date picker prevents invalid dates
- [ ] **Corrupted Data**: (Manual test)
  - [ ] App handles gracefully
  - [ ] No crashes

## Stress Testing
- [ ] Add 50+ tasks
- [ ] Search with various keywords
- [ ] Toggle between categories rapidly
- [ ] Change sort multiple times
- [ ] Toggle theme multiple times
- [ ] Mark many tasks complete
- [ ] No crashes or freezes

## Final Checks
- [ ] App is stable and responsive
- [ ] All features working as expected
- [ ] No console errors or warnings
- [ ] Data persists correctly
- [ ] Notifications work (if enabled)
- [ ] UI looks good on phone screen size
- [ ] No memory leaks (check RAM usage)

## Known Limitations
- [ ] Data stored locally only (no cloud sync)
- [ ] No backup/export feature yet
- [ ] No recurring tasks
- [ ] No task sharing
- [ ] No offline sync

## Notes
- Tested on: _________________ (Phone model)
- Android Version: _________________ 
- Date: _________________
- Tester: _________________

---

**Status**: Ready for Production ✅
