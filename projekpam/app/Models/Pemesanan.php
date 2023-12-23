<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Pemesanan extends Model
{
    use HasFactory;
    protected $table = 'pemesanan';
    protected $fillable = [
        'user_id', 'kaos_id', 'ukuran', 'jumlah_pesanan', 'total_harga','status_pembayaran'
    ];

    public function kaos()
    {
        return $this->belongsTo(Kaos::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
