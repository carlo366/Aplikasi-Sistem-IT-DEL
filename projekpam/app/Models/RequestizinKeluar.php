<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RequestIzinKeluar extends Model
{
    use HasFactory;
    protected $table = 'requestizin_keluars';

    protected $fillable=['user_id','approver_role ','approver_id','reason','start_date','end_date','status'];
}
