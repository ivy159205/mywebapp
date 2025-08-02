using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MyWebApp.Models
{
    public class Product
    {
        public int Id { get; set; }

        [Required(ErrorMessage = "Tên sản phẩm là bắt buộc")]
        [StringLength(100)]
        public string Name { get; set; } = string.Empty;

        [StringLength(500)]
        public string? Description { get; set; }

        [Required(ErrorMessage = "Giá tiền là bắt buộc")]
        [Column(TypeName = "decimal(18, 2)")]
        [Display(Name = "Giá Tiền")]
        [Range(0.01, double.MaxValue, ErrorMessage = "Giá tiền phải lớn hơn 0")]
        public decimal Price { get; set; }

        [Display(Name = "Ngày Tạo")]
        public DateTime CreatedAt { get; set; }
    }
}