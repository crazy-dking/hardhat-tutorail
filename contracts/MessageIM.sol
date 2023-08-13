 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0 ;

/**
功能：可以供两个人对话 详细功能：
1. 发起会话：任意用户可发起会话，同时指定一个接受会话人
2. 进行会话：会话建立之后，会话双方可以进行交谈
3. 结束会话：任意一方可以进行结束，双方都结束之后，会话终结，双方不可再在该回话进行交流。
4. 再次会话：上次会话结束之后，任何人可借助该合约再次发起会话。
要求：
1.无需支持同时多个会话
2.可以存储10条两天记录，条数无需配置增加
3.会话结束后，需要删除本次会话所有记录
4.会话存续期间，不允许第三个发起会话或参与会话
5.记录发送人和发送时间
*/
// 遇到问题：UnimplementedFeatureError: Copying of type struct MessageIM.Message memory[] memory to storage not yet supported.
// solidity不支持动态数组直接复制到存储变量中。
contract MessageIM {
    // 此处如果没有其他功能，可以放到方法中。可以节约gas
    uint public maxCapacity = 10;

    struct Message{
        string message;
        address sender;
        uint256 sendTime;
    }
    struct Chat {
        // 初始化的人
        address initiator;
        // 接受人
        address receiver;
        // 是否在聊天
        bool isActive;
        // 聊天内容，这个地方需要使用定长数组，或者映射。solidity不支持动态数组直接复制到存储变量中。
        // tmd定长数组不能push
        Message[] messages;

        // 用映射方式传入
        // mapping(uint256 => Message) messages;
        // uint256 messageCount;
    }
    // 我想存储多个的会话
    // mapping(uint => Chat) public chats;
    Chat public chat;

    event ChatStarted(address initiator, address receiver);
    event MessageSent(address sender, string message);
    event ChatEnded();

    /**
     * 和receiver创建一个对话，如果这个人正在和别人对话，你将不能和他对话
     * @param receiver 对话人，我们要和谁对话
     */
    function startChat(address receiver) public {
        require(!chat.isActive, "A chat is already active");
        chat = Chat(msg.sender, receiver, true, new Message[](0));
        emit ChatStarted(msg.sender, receiver);        
    }
    /**
     * 给指定人发送消息
     * @param message 消息
     */
    function sendMessage(string memory message) public {
        require(chat.isActive, "Chat is not active");
        require(msg.sender == chat.initiator || msg.sender == chat.receiver, "Only participants can send messages");
        if (chat.messages.length >= maxCapacity) {
            chat.messages.pop();
        }
        chat.messages.push(Message(message,msg.sender,block.timestamp));
        emit MessageSent(msg.sender, message);
    }

    function endChat() public {
        require(chat.isActive, "Chat is not active");
        require(msg.sender == chat.initiator || msg.sender == chat.receiver, "Only participants can end the chat");
        chat.isActive = false;
        delete chat.messages;
        emit ChatEnded();
    }

    function getChatMessages() public view returns (Message[] memory) {
        return chat.messages;
    }

}