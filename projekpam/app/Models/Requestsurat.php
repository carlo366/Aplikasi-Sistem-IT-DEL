<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Requestsurat extends Model
{
    use HasFactory;

    protected $table = 'requestsurats';

    protected $fillable = ['user_id','approver_id', 'reason','pengajuan','status'];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

}
