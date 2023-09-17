resource "local_file" "main" {
  content = "${var.file_content}"
  filename = "${path.module}/${var.file_name}.txt"
}