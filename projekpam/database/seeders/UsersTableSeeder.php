<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UsersTableSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        User::create([
            'ktp' => '123456789', // Replace with the desired KTP value
            'nim' => 'A12345678', // Replace with the desired NIM value
            'fullname' => 'BAK Staff', // Replace with the desired full name
            'phone' => '1234567890', // Replace with the desired phone number
            'email' => 'baak@example.com', // Replace with the desired email
            'password' => Hash::make('password'), // Replace with the desired password
            'role' => 'baak',
        ]);
    }
}
