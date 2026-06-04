require('dotenv').config();

const express = require('express');
const cors = require('cors');
const { MongoClient } = require('mongodb');

const app = express();
const port = process.env.PORT || 3000;
const mongoUri = process.env.MONGODB_URI || 'mongodb+srv://vikasmora:vikas@cluster0.tnddabx.mongodb.net/';
const databaseName = process.env.MONGODB_DB || 'app_temple_mobile';
const usersCollectionName = 'users';
const fixedOtp = '1234';

app.use(cors());
app.use(express.json());

const client = new MongoClient(mongoUri);
let usersCollection;

async function connectDatabase() {
  if (!usersCollection) {
    await client.connect();
    const database = client.db(databaseName);
    usersCollection = database.collection(usersCollectionName);
    await usersCollection.createIndex({ mobileNumber: 1 }, { unique: true });
  }
  return usersCollection;
}

app.get('/health', (_req, res) => {
  res.json({ ok: true });
});

app.post('/api/auth/request-otp', async (req, res) => {
  try {
    const mobileNumber = String(req.body.mobileNumber || '').trim();

    if (!/^\d{10}$/.test(mobileNumber)) {
      return res.status(400).json({ success: false, message: 'Enter a valid 10-digit mobile number.' });
    }

    const collection = await connectDatabase();
    const now = new Date();

    const result = await collection.updateOne(
      { mobileNumber },
      {
        $setOnInsert: {
          mobileNumber,
          createdAt: now,
        },
        $set: {
          lastOtpRequestedAt: now,
        },
      },
      { upsert: true }
    );

    res.json({
      success: true,
      message: result.upsertedCount > 0 ? 'User created and OTP requested.' : 'OTP requested for existing user.',
    });
  } catch (error) {
    console.error('request-otp error:', error);
    res.status(500).json({ success: false, message: 'Unable to request OTP.' });
  }
});

app.post('/api/auth/login', async (req, res) => {
  try {
    const mobileNumber = String(req.body.mobileNumber || '').trim();
    const otp = String(req.body.otp || '').trim();

    if (!/^\d{10}$/.test(mobileNumber)) {
      return res.status(400).json({ success: false, message: 'Enter a valid 10-digit mobile number.' });
    }

    if (otp !== fixedOtp) {
      return res.status(401).json({ success: false, message: 'Invalid OTP.' });
    }

    const collection = await connectDatabase();
    const now = new Date();

    const userResult = await collection.findOneAndUpdate(
      { mobileNumber },
      {
        $setOnInsert: {
          mobileNumber,
          createdAt: now,
        },
        $set: {
          lastLoginAt: now,
        },
      },
      {
        upsert: true,
        returnDocument: 'after',
        includeResultMetadata: true,
      }
    );

    return res.json({
      success: true,
      message: 'Login successful.',
      user: {
        mobileNumber: userResult?.value?.mobileNumber || mobileNumber,
      },
    });
  } catch (error) {
    console.error('login error:', error);
    res.status(500).json({ success: false, message: 'Unable to login.' });
  }
});

app.listen(port, () => {
  console.log(`Temple auth server listening on port ${port}`);
});
