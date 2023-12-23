<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class booking_ruangan extends Model
{
    use HasFactory;
    protected $table = 'booking_ruangan';

    protected $fillable = [
        'user_id',
        'reason',
        'status',
        'room_id',
        'start_time',
        'end_time',
    ];

    // Relasi dengan model User
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Relasi dengan model Ruangan
    public function ruangan()
    {
        return $this->belongsTo(Ruangan::class, 'room_id');
    }
    public function getRuanganNameAttribute()
{
    return $this->ruangan->NamaRuangan;
}
}
