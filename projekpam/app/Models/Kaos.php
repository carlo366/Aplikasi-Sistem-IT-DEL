<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Kaos extends Model
{
    use HasFactory;
    protected $table = 'kaos';
    protected $fillable = [
        'ukuran', 'harga',
    ];

    public function pemesanan()
    {
        return $this->hasMany(Pemesanan::class);
    }
}
